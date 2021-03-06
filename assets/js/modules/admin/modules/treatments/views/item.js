define([
	
	'jquery',
	'backbone',
	'text!modules/admin/modules/treatments/templates/itemTemplate.html',
	'sweetalert'	

], function($, Backbone, itemTemplate) {

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
	            url : '/api/treatments?id='+id+'&condition=delete&page='+page,
	            type: "POST",
	            dataType: "json",
	            async: false,
	            success: function(){	            	
	            	setTimeout(
	            		swal("Удалено!", "Запись успешно удалена.", "success"), 1000)
	            	window.location = page;
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
		render: function() {
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