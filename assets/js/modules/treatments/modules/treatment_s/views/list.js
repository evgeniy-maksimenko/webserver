define([

	'backbone',
	'layouts/layoutBasic/layout',
	'text!modules/treatments/modules/treatment_s/templates/listTemplate.html',
	'modules/treatments/modules/treatment_s/views/item',
	'modules/treatments/modules/treatment_s/collections/treatment'

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