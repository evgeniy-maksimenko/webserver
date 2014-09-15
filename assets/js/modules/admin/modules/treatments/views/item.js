define([
	'backbone',
	'text!modules/admin/modules/treatments/templates/itemTemplate.html'
], function(Backbone, itemTemplate) {
	var ItemPage = Backbone.View.extend({
		template : _.template(itemTemplate),
		tagName: 'tr',
		render: function() {
			this.$el.html(this.template(this.model.toJSON()));
			return this;
		}
	});

	return ItemPage;
});