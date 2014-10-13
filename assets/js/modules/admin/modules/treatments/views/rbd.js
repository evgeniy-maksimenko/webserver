define([

	'backbone',
	'layouts/layoutAdmin/layout',
	'text!modules/admin/modules/treatments/templates/rbdTemplate.html',
	'modules/admin/modules/treatments/views/item',
	'modules/admin/modules/treatments/collections/rbd'

], function(Backbone, Layout, listTemplate, ItemView, Collection) {
	
	var List = Backbone.View.extend({
		
		template: _.template(listTemplate),
		
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
		content: List
	});

});