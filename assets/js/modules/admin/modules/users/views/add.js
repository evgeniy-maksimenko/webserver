define([
	'jquery',
	'backbone',
	'layouts/layoutAdmin/layout',
	'text!modules/admin/modules/users/templates/addTemplate.html',
	'alertify',
	'modules/admin/modules/users/collections/user',
	'sweetalert',
	
	

], function($, Backbone, Layout, addTemplate, alertify, ModelUser) {
	var ViewPage = Backbone.View.extend({
		
		template: _.template(addTemplate),
		
		
		events: {
			'submit' : 'formSubmitted' 
		},
		render: function() {
			this.$el.html(this.template(this));
			return this;
		},
		formSubmitted: function(e) {
			e.preventDefault();

			$.ajax({
	            url : 		"/api/users?condition=add_user",
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