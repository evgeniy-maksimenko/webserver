define([

	'backbone',
	'layouts/layoutBasic/layout',
	'text!modules/workorders/templates/editTemplate.html',
	'router',
	'modules/workorders/collections/order',
	'modules/workorders/views/editView',
	
],function(Backbone, Layout, editTemplate, router, ModelOrder, EditView){	

	OrderEdit = Backbone.View.extend({
	     
	    template: _.template( editTemplate),

	    render: function() {

	    	var args = router.routeArguments();
	        
	        var value = 

	        $.ajax({
                url : '/api/get_order_info?wo-oid='+args.id,
                type: "POST",
                dataType: "json",
                async: false,
                success: function(data){
                     
                }
            });
	        
	        this.$el.html( this.template( value.responseJSON ) );
	        
	        this.renderSuccess();
	        return this;
	    },
	    renderSuccess: function() {
	        $("#wo-solution").focus();
	        //new app.OrderClose();
	    }
	});

	return Layout.extend({
		content: OrderEdit
	});
});
