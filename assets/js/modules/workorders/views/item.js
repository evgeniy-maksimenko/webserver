define([

	'backbone',
	'text!modules/workorders/templates/itemTemplate.html',
	'modules/workorders/models/order',
    'modules/workorders/views/info',

],function(Backbone, indexTemplate, Order, InfoView){	
	
	var ItemPage = Backbone.View.extend({
		tagName: 'tr',
		events: {
            'click' : 'get_more_info'
        },
		template : _.template(indexTemplate),
		render: function(){
            this.$el.attr('id',this.model.get("DT_RowId")).attr('workgroup',this.model.get("workgroup")).attr('appointed',this.model.get(9)).css( 'cursor', 'pointer' ).html( this.template( {
                bid_number  : this.model.get(0),
                created_at  : this.model.get(1),
                author      : this.model.get(2),
                oc          : this.model.get(3),
                title       : this.model.get(4),
                status      : this.model.get(5),
                order_number: this.model.get(6),
                priority    : this.model.get(7),
                group       : this.model.get(8),
                appointed   : this.model.get(9),
            }));
            return this;
        },
        get_more_info: function() {
            
            $('tr').removeClass('info');
            this.$el.addClass('info');
            
            var id          = this.$el.attr('id');
            var workgroup   = this.$el.attr('workgroup');
            var isAppointed = false;
            
            if(this.$el.attr('appointed') != '')
            {
                isAppointed = true;
            }
            $.ajax({
                url : '/api/get_order_info?wo-oid='+id,
                type: "POST",
                dataType: "json",
                success: function(data){
                     new InfoView(data, workgroup, isAppointed);

                }
            })
        }
	});

	return ItemPage;
	
});