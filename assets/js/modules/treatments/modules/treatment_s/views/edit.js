define([
	'backbone',
	'layouts/layoutBasic/layout',
	'text!modules/treatments/modules/treatment_s/templates/editTemplate.html',
	'router',
	'modules/treatments/modules/treatment_s/collections/treatment',
	'text!templates/forbiddenTemplate.html',
], function(Backbone, Layout, editTemplate, router, Collection, forbiddenTemplate) {

	var websocket;
	var whl = window.location.host;
	//var whl = '10.56.0.190:8008';

	function connect() {		
		wsUrl = "ws://" + whl + "/websocket";
		websocket = new WebSocket(wsUrl);
	};


	function getData(attrs) {
	    var data = 
	        $.ajax({
	            url : '/api/treatments?id='+attrs.id+'&condition=open',
	            type: "POST",
	            dataType: "json",
	            async: false,
	            success: function(data){}
	        });
	    return data;
	};

	var EditPage = Backbone.View.extend({
		template: _.template(editTemplate),
		forbiddenTpl: _.template(forbiddenTemplate),
		initialize : function(){
			connect();
		},
		events: {
			'submit' : 'recordIsMade' 
		},
		render: function() {
			
			var attrs = router.routeArguments();
			var data  = getData(attrs);
			if((data.status == 403) || (data.status == 400))
			{
				this.$el.html(this.forbiddenTpl(this));	
			}
			else
			{
				var arrayData =data.responseJSON;
				this.$el.html(this.template(arrayData[0]));
			}			
			return this;
		},
		recordIsMade: function(e) {
			e.preventDefault();
			var attrs = router.routeArguments();
	
			$.ajax({
	            url : '/api/treatments?condition=made&id='+attrs.id,
	            type: "POST",
	            dataType: "json",
	            data: $("form").serialize(),
	            success: function(){
	            	if(websocket.readyState == websocket.OPEN) {				
						var data = {action : "close_tm", id: attrs.id};
						websocket.send(JSON.stringify(data));
						
						window.location = '/treatment_s';
					} else {
						alert('websocket is not connected');
					}	              
	            }
	        });
		}
	});

	return Layout.extend({
		content: EditPage
	})
});