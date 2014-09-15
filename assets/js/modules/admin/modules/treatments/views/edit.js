define([
	'backbone',
	'layouts/layoutAdmin/layout',
	'text!modules/admin/modules/treatments/templates/editTemplate.html',
	'router',
	'modules/admin/modules/treatments/collections/treatment'
], function(Backbone, Layout, editTemplate, router, Collection) {

	function getData(attrs) {
	    var data = 
	        $.ajax({
	            url : '/api/treatments?id='+attrs.id+'&condition=open',
	            type: "POST",
	            dataType: "json",
	            async: false,
	            success: function(data){}
	        });
	    return data;
	};

	var EditPage = Backbone.View.extend({
		template: _.template(editTemplate),
		render: function() {
			var attrs = router.routeArguments();
			var data  = getData(attrs);
			var arrayData =data.responseJSON;
			this.$el.html(this.template(arrayData[0]));
			return this;
		}
	});

	return Layout.extend({
		content: EditPage
	})
});