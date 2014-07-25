var app = app || {};

$(function(){
    $('.selectpicker').selectpicker();
    /*
    switch (location.pathname) {
        case '/order' :
            console.log('/order');
            break;
        case '/order/edit' :
            console.log('/order/edit');
            break;
    };
    */

    app.Router = Backbone.Router.extend({
        routes: {
            'order' : 'index',
            'order/edit/:id' : 'edit'
        },
        index: function() {
            new app.OrderViews();
        },
        edit: function(id) {
            $.ajax({
                url : '/api/get_order_info?wo-oid='+id,
                type: "POST",
                dataType: "json",
                success: function(data){
                    new app.OrderEdit(data);
                }
            })
        }
    });

    new app.Router();
    Backbone.history.start({pushState: true});

});
