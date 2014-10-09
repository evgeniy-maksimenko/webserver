define([
	'jquery',
	'backbone',
	'layouts/layoutBasic/layout',
	'text!modules/treatments/modules/treatment_f/templates/listTemplate.html',
	'modules/treatments/modules/treatment_f/views/item',
	'modules/treatments/modules/treatment_f/collections/treatment'

], function($, Backbone, Layout, listTemplate, ItemView, Collection) {

	var websocket;

	var whl = window.location.host;
	//var whl = '10.56.0.190:8008';

	function connect() {
		
		wsUrl = "ws://" + whl + "/websocket";
		websocket = new WebSocket(wsUrl);
		websocket.onmessage = function(evt) { onMessage(evt) };		
	};

	function onMessage(evt) { 

        var data = $.parseJSON(evt.data);    
        switch (data.action) {
        	case "new_tm":
        		showScreen(data); 	
        		break
        	case "work_tm":
        		Message_btn(data);
        		break
        	case "close_tm":
        		Message_closer(data);
        		break
        };
        
    };

	function Message_btn(data) { 
        $("#work"+data.id).remove();
        $("#in_work"+data.id).show();
        $("#status"+data.id).show();
    };

    function Message_closer(data) { 

        $("#in_work"+data.id).parent().parent().remove();

    };

    function showScreen(data) { 
    	var d = new Date();
    	
    	var dd = d.getDate();
    	if ( dd < 10 ) dd = '0' + dd;
    	var mm = d.getMonth()+1 ;
    	if ( mm < 10 ) mm = '0' + mm;

    	var hh = d.getHours();
    	if ( hh < 10 ) hh = '0' + hh;
    	var m = d.getMinutes();
    	if ( m < 10 ) m = '0' + m;
    	var s = d.getSeconds();
    	if ( s < 10 ) s = '0' + s;
    	

    	var datetime = d.getFullYear() + '-' + mm + '-' +dd+ ' '+ hh+':'+m+':'+s;
    	
    	$('#list').prepend('<tr class="'+data.id+'"><td>'+data.email+'</td><td>'+data.phone+'</td><td>'+data.vopros+'</td><td style="width:30px;">'+datetime+'</td><td style="width:30px;"><div class="in_work btn btn-success" id="work'+data.id+'" data="'+data.id+'">в работу</div><a class="btn btn-danger" id="in_work'+data.id+'" href="/treatment_f/edit/'+data.id+'" style="display:none;">закрыть</a></td><td style="width:30px;"><span class="status label label-danger" id="status'+data.id+'" style="display:none;">В работе</span></td></tr>');
    	$("."+data.id).css('backgroundColor', 'yellow').animate({ backgroundColor: "white"}, 3000);

	}    	
	var List = Backbone.View.extend({
		
		template: _.template(listTemplate),
		events: {
			'click .in_work' : 'in_work'
		},
		initialize: function() {
			connect();

			this.collection = new Collection();
			this.collection.fetch({
				reset: true
			});
			this.listenTo(this.collection, 'reset', this.render);
			return this;
		},

		render: function() {
			this.$el.html(this.template(this));
			this.collection.each(this.renderOne, this);
			return this;
		},
		renderOne: function(item) {
			var itemView = new ItemView({
				model: item
			});
			$("#list").append(itemView.render().el);
		},
		in_work: function(event) {
			var record_id = $(event.currentTarget).attr('data');
			if(websocket.readyState == websocket.OPEN) {				
				var data = {action : "work_tm", id: record_id};
				websocket.send(JSON.stringify(data));
			} else {
				alert('websocket is not connected');
			}
			$.ajax({
	            url : '/api/treatments?condition=in_work&id='+record_id,
	            type: "POST",
	            dataType: "json",
	            success: function(){
	            }
	        });
				
		}
	});

	return Layout.extend({
		content: List
	});

});