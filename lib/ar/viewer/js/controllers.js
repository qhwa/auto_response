/**
 * Network Tab Controller.
 */
angular.module('net', []).controller('NetworkCtrl', function ($scope) {
  'use strict';

  $scope.segments = 12; // Hard-coded number of segments
  $scope.pages = $scope.pages || []; // Page -> Entry mapping
  $scope.entries = $scope.entries || []; // Entries
  $scope.data = {}; // Global data

  $scope.checked = false;
  $scope.tab = '1';
  $scope.sI = 'all';
  $scope.selectedEntry = null;

  $scope.updateHar = function(new_data) {
    // Reset data
    var data = {};
    data.lastOnLoad = 0;

    // Handle pages
    var pageidxs = {};

    // Handle entries
    var entries = new_data.log.entries;
    delete new_data.log.entries;
    $.each(entries, function(i, entry) {
      var harEntry = new HAREntry(
        entry,
        i,
        new Date( entry.startedDateTime ).getTime(),
        data
      );
      harEntry.autoResponded = entry.comment == 'x-auto-response'
      harEntry.response_content = entry.response.content;
      entries[i] = harEntry;
    });

    // Latch values
    $scope.entries = entries;
    $scope.checked = true;
    $scope.data = data;

    // Create labels for segments
    $scope.labels = $scope.setLabels($scope.data.lastOnLoad/$scope.segments);
  };

  $scope.setLabels = function(section) {
    var labels = {};
    for (var i = 12; i > 0; i--) {
      labels[i] = String.sprintf("%0.00fms", section * i);
    };
    return labels;
  };

  $scope.setSort = function(sort) {
    $scope.predicate = sort;
    $scope.reverse = !$scope.reverse;
  };

  $scope.toggleReqHeaders = function() {
    $('.request.parent').toggleClass('expanded');
    $('.request.children').toggleClass('expanded');
  };

  $scope.toggleResHeaders = function() {
    $('.response.parent').toggleClass('expanded');
    $('.response.children').toggleClass('expanded');
  };

  $scope.showDetails = function(i) {
    $scope.selectedRow = i;
    $scope.selectedEntry = $scope.entries[i];

    var $leftView = $('.split-view-sidebar-left');
    $('#network-views').removeClass('hidden');
    $('.panel.network').addClass('viewing-resource');
    $leftView.removeClass('maximized');
    $leftView.addClass('minimized');
    $('#network-container').addClass('brief-mode');
  };

  $scope.hideDetails = function() {
    $scope.selectedRow = '-1';
    var $leftView = $('.split-view-sidebar-left');
    $leftView.addClass('maximized');
    $('#network-views').addClass('hidden');
    $('.panel.network').removeClass('viewing-resource');
    $leftView.removeClass('minimized');
    $('#network-container').removeClass('brief-mode');
  };

  // TODO: merge all these get/set index functions.
  $scope.getClass = function (type) {
    return ( (type == $scope.sI) ? 'selected' : '');
  };

  $scope.getSelectedRow = function (i) {
    return ( (i == $scope.selectedRow) ? 'selected' : '');
  };

  $scope.getTab = function(index) {
    return ( (index == $scope.tab) ? 'selected' : '');
  };

  $scope.getVisibleTab = function(index) {
    return ( (index == $scope.tab) ? 'visible' : '');
  };

  $scope.showTab = function(index) {
    $scope.tab = index;
  };

  $scope.dnd = {};

  $scope.dnd.cancel = function (e) {
    if (e.preventDefault) {
      e.preventDefault(); // required by FF + Safari
    }
    return false; // required by IE
  }

});
