define([
	'backbone',
	'layouts/layoutBasic/layout',
	'text!modules/treatments/modules/treatment_s/templates/editTemplate.html',
	'router',
	'modules/treatments/modules/treatment_s/collections/treatment'
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
		events: {
			'submit' : 'recordIsMade' 
		},
		render: function() {
			var attrs = router.routeArguments();
			var data  = getData(attrs);
			var arrayData =data.responseJSON;
			this.$el.html(this.template(arrayData[0]));
			return this;
		},
		recordIsMade: function(e) {
			e.preventDefault();
			var attrs = router.routeArguments();
			$.ajax({
	            url : '/api/treatments?condition=made&id='+attrs.id,
	            type: "POST",
	            dataType: "json",
	            data: $("form").serialize(),
	            success: function(){
	                //window.location = "/treatment_f";
	            }
	        });
		}
	});

	return Layout.extend({
		content: EditPage
	})
});