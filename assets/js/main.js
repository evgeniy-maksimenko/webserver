define([], function() {
  'use strict';
	
	requirejs.config({
		paths: {
			'jquery' 			: 'libs/jquery/jquery-1.11.1.min',
			'underscore' 		: 'libs/underscore/underscore',
			'backbone' 			: 'libs/backbone/backbone',
			'bootstrap'			: 'libs/bootstrap/bootstrap.min',
			'bootstrap-select' 	: 'libs/bootstrap/bootstrap-select.min',
			'jquery-cookie'		: 'libs/jquery/jquery.cookie',
			'jquery-ui'			: 'libs/jquery/jquery-ui',

			'router' 		: 'libs/rjs/rjs-router',
			'text' 			: 'libs/rjs/rjs-text'
		},

		shim: {
			'backbone' : {
				deps 	: ['jquery', 'underscore','bootstrap','bootstrap-select','jquery-cookie','jquery-ui'],
				exports : 'Backbone'
			}
		}
	});

	require([
		'jquery',
		'router'
	], function($, router) {
		var view;
		router.registerRoutes({
			home: 		{ path: '/', 					moduleId: 'views/home'},
			admin: 		{ path: '/admin', 				moduleId: 'modules/admin/views/index'},
			sidebar1: 	{ path: '/workorders', 			moduleId: 'modules/workorders/views/list' },
			sidebar2: 	{ path: '/workorders/:id', 		moduleId: 'modules/workorders/views/list' },
			sidebar3:   { path: '/workorders/edit/:id', moduleId: 'modules/workorders/views/edit'},
			sidebar4: 	{ path: '/test', 				moduleId: 'modules/workorders/views/test' },
			notFound: 	{ path: '*',					moduleId: 'views/notFound'},
		
		}).on('routeload', function onRouteLoad(View, routeArguments) {
			if (view) {
	          view.remove();
	        }
	        view = new View(null, routeArguments);
	        view.render();
	        $('body').append(view.el);
		}).init();

	});
});