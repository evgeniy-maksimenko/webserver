var app = app || {};

app.Orders = Backbone.Collection.extend({
    model: app.Order,
    url: '/api/test'
});