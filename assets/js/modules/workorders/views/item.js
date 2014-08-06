define([
	
	'backbone',
	'text!modules/workorders/templates/indexTemplate.html',
	'modules/workorders/models/order',

],function(Backbone, indexTemplate, Order){	
	
	var ItemPage = Backbone.View.extend({		
		tagName: 'li',
		template : _.template(indexTemplate),
		render: function() {

			this.$el.html(this.template(this.model.toJSON()));
			return this;
		}
	});

	return ItemPage;
});
