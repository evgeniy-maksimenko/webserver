define([

	'backbone',
	'text!modules/workorders/modules/record/templates/viewTemplate.html',
	
], function(Backbone, recordTemplate){
	var RecordPage = Backbone.View.extend({

		template: _.template(recordTemplate),

		render: function() {
			this.$el.html(this.template(this.model.toJSON()));
			return this;
		}
	});

	return RecordPage;
});