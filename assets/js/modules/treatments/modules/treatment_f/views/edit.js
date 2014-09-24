define([
	'backbone',
	'layouts/layoutBasic/layout',
	'text!modules/treatments/modules/treatment_f/templates/editTemplate.html',
	'router',
	'modules/treatments/modules/treatment_f/collections/treatment',
	'text!templates/forbiddenTemplate.html',
], function(Backbone, Layout, editTemplate, router, Collection, forbiddenTemplate) {

	var ws_closer;
	function connect_closer() {
		wsUrl = "ws://" + window.location.host + "/ws_closer";
		ws_closer = new WebSocket(wsUrl);		
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
			connect_closer();
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
	            	if(ws_closer.readyState == ws_closer.OPEN) {				
						ws_closer.send(attrs.id);
						window.location = '/treatment_f';
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