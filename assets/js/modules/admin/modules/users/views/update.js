define([
	'jquery',
	'backbone',
	'layouts/layoutAdmin/layout',
	'text!modules/admin/modules/users/templates/updateTemplate.html',
	'router',
	'alertify',
	'sweetalert',
	

], function($, Backbone, Layout, updateTemplate, router, alertify) {
	
	function viewData(attrs) {
	    var data = 
	        $.ajax({
	            url : 		'/api/users?id='+attrs.id+'&condition=view',
	            type: 		"POST",
	            dataType: 	"json",
	            async: 		false,
	            success: function(data){}
	        });
	    return data;
	};

	var ViewPage = Backbone.View.extend({		
		template: _.template(updateTemplate),
		events: {
			'submit' : 'formSubmitted' 
		},
		render: function() {
			var attrs = router.routeArguments();
			var data  = viewData(attrs);
			var JsonData = data.responseJSON;


			this.$el.html(this.template(JsonData[0]));
			return this;
		},
		formSubmitted: function(e) {
			e.preventDefault();

			$.ajax({
	            url : 		"/api/users?condition=update",
	            type: 		"POST",
	            dataType: 	"json",
	            data: 		$("form").serialize(),
	            success: function(data){
	            	swal("Сохранено!", data.status, "success");
	            	alertify.success(data.status);
	            }
	        });
		}
	});

	return Layout.extend({
		content: ViewPage
	})
});