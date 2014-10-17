define([
	
	'backbone',
	'text!modules/admin/modules/users/templates/itemTemplate.html',
	'alertify',
	'sweetalert'	

], function(Backbone, itemTemplate, alertify) {

	function confirm_delete_alert(id, page) {
		swal({
		  	title: "Вы подтверждаете удаление?",
		  	type: "warning",
		  	showCancelButton: true,
		  	confirmButtonColor: "#DD6B55",
		  	confirmButtonText: "Да, я подверждаю!",
		  	closeOnConfirm: false
		},
		function(){
			getData(id, page);
		});
	}

	function getData(id, page) {

	    var data = 
	        $.ajax({
	            url : '/api/users?condition=delete&id='+id,
	            type: "POST",
	            dataType: "json",
	            async: false,
	            success: function(data){	            	
	            	setTimeout(
	            		swal("Удалено!", data.status, "success"), 1000)
	            		$("#row"+id).parent().remove();
	            		alertify.success(data.status);
	            }
	        });
	    return data;
	};

	var ItemPage = Backbone.View.extend({
		template : _.template(itemTemplate),
		
		tagName: 'tr',
		events: {
			'click .delete' : 'delete'
		},
		render: function(model) {
			this.$el.html(this.template(this.model.toJSON()));
			return this;
		},
		delete: function(e) {
			var currentLocation = window.location;
			var data = $(e.currentTarget);
			confirm_delete_alert(data.attr('id'),currentLocation);
		}
	});

	return ItemPage;
});