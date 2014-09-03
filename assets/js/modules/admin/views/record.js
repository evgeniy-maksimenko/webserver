define([

	'backbone',
	'text!modules/admin/templates/recordTemplate.html'
	
], function(Backbone, recordTemplate){
	var RecordPage = Backbone.View.extend({
		tagName: 'tr',
		template: _.template(recordTemplate),

		render: function() {
			this.$el.html(this.template(this.model.toJSON()));
			return this;
		}
	});

	return RecordPage;
});