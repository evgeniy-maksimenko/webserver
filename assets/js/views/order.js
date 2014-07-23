var app = app || {};

app.OrderInfo = Backbone.View.extend({
    el: '#orderInfo',
    template: _.template( $("#orderInfoTemplate").html()),
    initialize: function(data){
        this.render(data);
    },
    render: function(data) {
        this.$el.html( this.template( data ) );
        return this;
    }
});

app.OrderView = Backbone.View.extend({
    tagName: 'tr',
    className: 'orderId',
    events: {
        'click' : 'get_more_info'
    },
    template: _.template( $("#orderTemplate").html()),
    render: function(){
        this.$el.attr('id',this.model.get("DT_RowId")).css( 'cursor', 'pointer' ).html( this.template( {
            bid_number  : this.model.get(0),
            created_at  : this.model.get(1),
            author      : this.model.get(2),
            oc          : this.model.get(3),
            title       : this.model.get(4),
            status      : this.model.get(5),
            order_number: this.model.get(6),
            priority    : this.model.get(7),
            group       : this.model.get(8),
            appointed   : this.model.get(9)
        }));
        return this;
    },
    get_more_info: function() {
        var id = this.$el.attr('id');

        $.ajax({
            url : '/api/get_order_info?wo-oid='+id,
            type: "POST",
            dataType: "json",
            success: function(data){
                new app.OrderInfo(data);
            }
        })
    }
});

