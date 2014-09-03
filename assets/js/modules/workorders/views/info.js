define([

	'backbone',
	'text!modules/workorders/templates/infoTemplate.html',
	'layouts/layoutBasic/layout',
  'modules/workorders/views/list',
  'text!modules/workorders/templates/contactTemplate.html',

],function(Backbone, infoTemplate, Layout, ListView, contactTemplate){

  function getData(login) {
      var data = 
          $.ajax({
              url : '/api/get_user_contacts?login='+login,
              type: "POST",
              dataType: "json",
              async: false,
              success: function(data){}
          });
      return data;
  };

	var OrderInfo = Backbone.View.extend({
        el: '#orderInfo',
        template: _.template(infoTemplate),
        ContactTemplate: _.template(contactTemplate),
        events: {
            'click #set_order_work' : 'orderInWork',
            'submit #workaround-form' : 'workaroundForm',
        },
        initialize: function(data, workgroup, isAppointed){
            this.render(data, workgroup, isAppointed);
        },
        render: function(data, workgroup, isAppointed) {
            
            var contacts  = getData(data.requestor);
            
            this.$el.html( this.template( data ) );


            $("#user_contacts").html( this.ContactTemplate(contacts.responseJSON) );

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
        },
        workaroundForm: function(e) {

          e.preventDefault();

          $.ajax({
              url: '/api/post_workaround',
              type: "POST",
              dataType: "json",
              data: $("form").serialize(),
              success: function(){
                  window.location = "/workorders";
              }
          });
        }
    });

    return OrderInfo;
});