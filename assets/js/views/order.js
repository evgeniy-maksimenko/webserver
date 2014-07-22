var app = app || {};

app.OrderView = Backbone.View.extend({
    tagName: 'div',
    className: 'orderContainer',
    template: _.template( $("#orderTemplate").html()),
    render: function(){
        this.$el.html( this.template( this.model.toJSON() ));
        return this;
    }
});