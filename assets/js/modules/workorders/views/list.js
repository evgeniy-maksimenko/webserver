define([

	'backbone',
	'underscore',
	'modules/workorders/collections/orders',
	'modules/workorders/views/item',
	'layouts/layoutBasic/layout'

],function(Backbone, _, OrdersCollection, OrderView, Layout) {
	
	var View1 = Backbone.View.extend({
		
		tagName: 'ul',
		initialize: function() {
			this.collection = new OrdersCollection();
	        this.collection.fetch({
	        	reset:true
	        });
	       	this.listenTo(this.collection, 'reset', this.render); 
		},
		render: function() {
			this.collection.each(this.renderOrder,this);
			return this;
		},
		renderOrder: function(item) {
			var orderView = new OrderView({
            	model: item
	        });
	        this.$el.append(orderView.render().el);
	        return this;
		}
	});
	
	return Layout.extend({
		content: View1
	});
});
