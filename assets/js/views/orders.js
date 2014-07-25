var app = app || {};

app.OrderViews = Backbone.View.extend({
    el: '#orders',

    initialize: function(){
        this.$el.empty();
        this.collection = new app.Orders();
        this.collection.fetch({reset:true});
        this.render();
        this.listenTo(this.collection, 'reset', this.render);
    },
    render: function() {
        this.collection.each(function(item){
            this.renderOrder(item);
        }, this)
    },
    renderOrder: function(item){
        var orderView = new app.OrderView({
            model: item
        });
        this.$el.append(orderView.render().el);
    }
});

app.OrderEdit = Backbone.View.extend({
    el: '#orderInfo',
    template: _.template( $("#orderInfoTemplate").html()),
    initialize: function(data){
        this.render(data);
    },
    render: function(data) {
        this.$el.html( this.template( data ) );
        this.renderSuccess();
        return this;
    },
    renderSuccess: function() {
        $("#wo-solution").focus();
        new app.OrderClose();
    }
});

app.OrderClose = Backbone.View.extend({
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
                window.location = "/order";
            }
        });
    }
});