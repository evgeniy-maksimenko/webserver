define([

	'backbone',
	'layouts/layoutBasic/layout',
	'text!modules/workorders/templates/editTemplate.html',
	'router',
	'modules/workorders/collections/order',
	'modules/workorders/views/closeView',
	
],function(Backbone, Layout, editTemplate, router, ModelOrder, closeView){	

	function getData(attrs) {
	    var data = 
	        $.ajax({
	            url : '/api/get_order_info?wo-oid='+attrs.id,
	            type: "POST",
	            dataType: "json",
	            async: false,
	            success: function(data){}
	        });
	    return data;
	};

	OrderEdit = Backbone.View.extend({
	    template: _.template( editTemplate),
	    events: {
	        'submit' : 'closeForm'
	    },
	    render: function() {
	    	var attrs = router.routeArguments();
	        var data = getData(attrs);
	        
	        this.$el.html( this.template( data.responseJSON ) );
	        
	        this.renderSuccess();
	        return this;
	    },
	    renderSuccess: function() {
	        $("#wo-solution").focus();
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

	return Layout.extend({
		content: OrderEdit
	});
});
