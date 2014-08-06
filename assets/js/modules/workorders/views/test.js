define(function(require){	
	
	'use strict';
	
	var Backbone		= require('backbone'),
		indexTemplate 	= require('modules/workorders/models/order');
	
	var ItemPage = Backbone.View.extend({		
		tagName: 'li',
		render: function() {
			this.$el.html("asdads");
			return this;
		}
	});

	return ItemPage;
});
