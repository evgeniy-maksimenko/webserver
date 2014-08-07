define([

	'backbone',
	'underscore',
	'modules/workorders/collections/orders',
	'modules/workorders/views/item',
	'layouts/layoutBasic/layout',
	'text!modules/workorders/templates/listTemplate.html'

],function(Backbone, _, OrdersCollection, OrderView, Layout, listTemplate) {
	
	var View1 = Backbone.View.extend({
		 
		template: _.template(listTemplate),

		initialize: function() {		
			this.$el.empty();
			this.collection = new OrdersCollection();
	        this.collection.fetch({
	        	reset:true
	        });
	        this.render();
	       	this.listenTo(this.collection, 'reset', this.render); 
		},
		render: function() {
			this.$el.html(this.template());

			this.collection.each(this.renderOrder,this);
			return this;
		},
		renderOrder: function(item) {
			var orderView = new OrderView({
            	model: item
	        });
	        $("#orders").append(orderView.render().el);
	        return this;
		}
	});
	
	return Layout.extend({
		content: View1
	});
});
