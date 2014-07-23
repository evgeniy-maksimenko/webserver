var app = app || {};

app.Orders = Backbone.Collection.extend({
    model: app.Order,
    url: '/api/get_all_orders?status=WORK&destinate=MY_GROUP'
});