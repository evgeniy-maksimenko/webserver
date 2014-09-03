define([
	'backbone'
], function(Backbone){
	var OrderClose = Backbone.View.extend({
	    el: "#close-form",
	    events: {
	        'submit' : 'closeForm'
	    },
	    closeForm: function(e) {
	    	alert(1);
	        e.preventDefault();
	        
	        var solution 		 = $("#solution").val();
	        var record_id 		 = $("#record_id").val();
	        
	        $.ajax({
	            url : '/api/close_order?record_id='+record_id+'&solution='+solution,
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