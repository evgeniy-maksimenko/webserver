define([
	'backbone',
	'text!modules/treatments/modules/treatment_f/templates/itemTemplate.html'
], function(Backbone, itemTemplate) {
	
	

	var ItemPage = Backbone.View.extend({
		template : _.template(itemTemplate),
		events: {
			'click .in_work' : 'in_work'
		},
		tagName: 'tr',
		initialize: function() {

		},
		render: function() {
			this.$el.html(this.template(this.model.toJSON()));
			return this;
		},
		in_work: function() {
			if(websocket.readyState == websocket.OPEN) {
				event_in_work = $("#event_in_work").val();
				websocket.send(event_in_work);
			} else {
				alert('websocket is not connected');
			}	
		}
	});

	return ItemPage;
});