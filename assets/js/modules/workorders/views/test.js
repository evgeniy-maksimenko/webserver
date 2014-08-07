define([

	'backbone',
	'modules/workorders/models/order',
	'layouts/layoutBasic/layout'
	
],function(Backbone, indexTemplate, Layout){	
	
	var ItemPage = Backbone.View.extend({		
		render: function() {
			this.$el.html("asdads");
			return this;
		}
	});

	return Layout.extend({
		content: ItemPage
	});
});
