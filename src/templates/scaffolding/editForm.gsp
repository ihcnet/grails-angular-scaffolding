<% import grails.persistence.Event %>
<div class="page-header">
    <h1>Edit ${className}</h1>
</div>
<alert level="{{message.level}}" text="{{message.text}}"/>

<form name="form" data-ng-submit="update(item)" class="form-horizontal">
    <input type="hidden" data-ng-model="item.id">
    <input type="hidden" data-ng-model="item.version">
    <g:render template="/ng-templates/${domainClass.propertyName}/edit"/>
    <div class="form-actions">
        <button type="submit" class="btn btn-primary" data-ng-disabled="form.\$invalid"><i class="icon-ok"></i> Update
        </button>
        <button type="button" class="btn btn-danger" data-ng-click="delete(item)"><i class="icon-trash"></i> Delete
        </button>
    </div>
</form>
