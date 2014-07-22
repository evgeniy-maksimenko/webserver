var app = app || {};

app.OrderViews = Backbone.View.extend({
    el: '#orders',
    initialize: function(){
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