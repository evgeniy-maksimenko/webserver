define([
	'backbone'
], function(Backbone){
	var OrderClose = Backbone.View.extend({
	    el: "#close-form",
	    events: {
	        'submit' : 'closeForm'
	    },
	    closeForm: function(e) {
	        e.preventDefault();
	        var solution = $("#wo-solution").val();
	        var id = $("#oid").val();
	        $.ajax({
	            url : '/api/close_order?id='+id+'&solution='+solution,
	            type: "POST",
	            dataType: "json",
	            success: function(){
	                window.location = "/workorders";
	            }
	        });
	    }
	});

	return OrderClose;
});