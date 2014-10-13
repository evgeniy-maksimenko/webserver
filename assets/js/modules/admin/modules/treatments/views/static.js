define([
	'backbone',
	'layouts/layoutAdmin/layout',
	'text!modules/admin/modules/treatments/templates/staticTemplate.html',
	'modules/admin/modules/treatments/collections/static'

], function(Backbone, Layout, viewTemplate, Collection) {

		function getData() {
		    var data = 
		        $.ajax({
		            url : '/api/treatments?condition=static',
		            type: "POST",
		            dataType: "json",
		            async: false,
		            success: function(data){}
		        });
		    return data;
		};

	var ViewPage = Backbone.View.extend({
		template: _.template(viewTemplate),
		 
		render: function() {
			var data  = getData();
			var arrayData =data.responseJSON;

			
			this.$el.html(this.template(arrayData));
			return this;
		}
	});

	return Layout.extend({
		content: ViewPage
	})
});