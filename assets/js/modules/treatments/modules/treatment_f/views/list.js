define([
	'jquery',
	'backbone',
	'layouts/layoutBasic/layout',
	'text!modules/treatments/modules/treatment_f/templates/listTemplate.html',
	'modules/treatments/modules/treatment_f/views/item',
	'modules/treatments/modules/treatment_f/collections/treatment'

], function($, Backbone, Layout, listTemplate, ItemView, Collection) {

	var websocket;
 
    function connect() {
    	wsUrl = "ws://" + window.location.host + "/websocket";
		websocket = new WebSocket(wsUrl);
		websocket.onmessage = function(evt) { onMessage(evt) };		
    };

    function onMessage(evt) { 
        var obj = $.parseJSON(evt.data);
    	
        
        showScreen(obj); 
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
    	$('#list').prepend('<tr class="'+data.sh_cli_id+'"><td>'+data.email+'</td><td>'+data.phone+'</td><td>'+data.vopros+'</td><td>'+datetime+'</td><td><a href="/treatment_f/edit/'+data.sh_cli_id+'"><span class="glyphicon glyphicon-info-sign"></span></a></td></tr>');
    	$("."+data.sh_cli_id).css('backgroundColor', 'yellow').animate({ backgroundColor: "white"}, 3000);
	}    	
	var List = Backbone.View.extend({
		
		template: _.template(listTemplate),
		
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
		}
	});

	return Layout.extend({
		content: List
	});

});