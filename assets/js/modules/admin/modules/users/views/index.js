define([
	
	'jquery',
	'backbone',
	'layouts/layoutAdmin/layout',
	'text!modules/admin/modules/users/templates/indexTemplate.html',
	'modules/admin/modules/users/views/item',
	'modules/admin/modules/users/collections/users',
	

], function($, Backbone, Layout, indexTemplate, ItemView, Collection) {


	var ViewPage = Backbone.View.extend({
		template: _.template(indexTemplate),
		initialize: function() {
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
		content: ViewPage
	})
});