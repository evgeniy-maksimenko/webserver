define([

	'backbone',
	'text!modules/workorders/templates/infoTemplate.html',
	'layouts/layoutBasic/layout',

],function(Backbone, infoTemplate, Layout, orderView){
	
	var OrderInfo = Backbone.View.extend({
        el: '#orderInfo',
        template: _.template(infoTemplate),
        initialize: function(data, workgroup, isAppointed){

            this.render(data, workgroup, isAppointed);
        },
        render: function(data, workgroup, isAppointed) {

            this.$el.html( this.template( data ) );

            $("#set_order_work").attr('oid',data.oid).attr("workgroup",workgroup);
            if(isAppointed == true)
            {
                  $("#set_order_work").attr('disabled','disabled');
                  $("#temp_result").removeAttr('disabled');
                  $("#close_order").removeAttr('disabled');
                  $("#close_dropdown").removeAttr('disabled');
            }            

            return this;
        }
    });

    return OrderInfo;
});