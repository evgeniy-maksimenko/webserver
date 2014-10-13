define([
	'jquery',
	'backbone',
	'text!modules/admin/modules/treatments/templates/itemTemplate.html'
], function($, Backbone, itemTemplate) {

	function getData(id, page) {
	    var data = 
	        $.ajax({
	            url : '/api/treatments?id='+id+'&condition=delete&page='+page,
	            type: "POST",
	            dataType: "json",
	            async: false,
	            success: function(){
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
			if (confirm("Вы подтверждаете удаление?")) {
				getData(data.attr('id'),currentLocation);
			} else {
				return false;
			}
		}
	});

	return ItemPage;
});