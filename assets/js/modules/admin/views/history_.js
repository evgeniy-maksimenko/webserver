define([

	'backbone',
	'text!modules/admin/templates/history_Template.html'
	
], function(Backbone, history_Template){
	var HistoryPage = Backbone.View.extend({
		tagName: 'tr',
		template: _.template(history_Template),

		render: function() {
			this.$el.html(this.template(this.model.toJSON()));
			return this;
		}
	});

	return HistoryPage;
});