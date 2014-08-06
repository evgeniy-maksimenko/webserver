define(function(require){

	'use strict';
	
	var Backbone 	  		= require('backbone'),
		_ 			 		= require('underscore'),
		OrdersCollection 	= require('modules/workorders/collections/orders'),
		OrderView 			= require('modules/workorders/views/item');
	
	var View1 = Backbone.View.extend({
		
		tagName: 'ul',
		initialize: function() {
			this.collection = new OrdersCollection();
	        this.collection.fetch({reset:true});
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
	
	return View1;
});
