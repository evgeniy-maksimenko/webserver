define([

	'backbone',
	'text!modules/workorders/templates/infoTemplate.html',
	'layouts/layoutBasic/layout',
  'modules/workorders/views/list',

],function(Backbone, infoTemplate, Layout, ListView){
	
	var OrderInfo = Backbone.View.extend({
        el: '#orderInfo',
        template: _.template(infoTemplate),
        events: {
            'click #set_order_work' : 'orderInWork',
        },
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
        },
        orderInWork : function() {
          
          var buttonOrderWord = $("#set_order_work");
          var oid       = buttonOrderWord.attr('oid');
          var workgroup = buttonOrderWord.attr('workgroup');
 
            $.ajax({
                url : '/api/set_order_work?oid='+oid+'&workgroup='+workgroup,
                type: "POST",
                dataType: "json",
                success: function(){
                  window.location = "/workorders/" + oid;    
                }
            });
        }
    });

    return OrderInfo;
});