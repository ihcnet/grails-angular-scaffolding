<% import grails.persistence.Event %>
<g:set var="${domainClass.name}SubPrefix" value="\${subPrefix ? subPrefix + '.' : ''}"/>
    <%  excludedProps = Event.allEvents.toList() << 'version' << 'dateCreated' << 'lastUpdated'
    persistentPropNames = domainClass.persistentProperties*.name
    boolean hasHibernate = pluginManager?.hasGrailsPlugin('hibernate')
    if (hasHibernate && org.codehaus.groovy.grails.orm.hibernate.cfg.GrailsDomainBinder.getMapping(domainClass)?.identity?.generator == 'assigned') {
        persistentPropNames << domainClass.identifier.name
    }
    props = domainClass.properties.findAll { persistentPropNames.contains(it.name) && !excludedProps.contains(it.name) }
    Collections.sort(props, comparator.constructors[0].newInstance([domainClass] as Object[]))
    for (p in props) {
        if (p.embedded) {
            def embeddedPropNames = p.component.persistentProperties*.name
            def embeddedProps = p.component.properties.findAll { embeddedPropNames.contains(it.name) && !excludedProps.contains(it.name) }
            Collections.sort(embeddedProps, comparator.constructors[0].newInstance([p.component] as Object[]))
    %><fieldset class="embedded"><legend>${p.naturalName}</legend><%
        for (ep in p.component.properties) {
            renderFieldForProperty(ep, p.component, "${p.name}.")
        }
%></fieldset><%
        } else {
            renderFieldForProperty(p, domainClass)
        }
    }

    private renderFieldForProperty(p, owningClass, prefix = "") {
        boolean hasHibernate = pluginManager?.hasGrailsPlugin('hibernate')
        boolean display = true
        boolean required = false
        if (hasHibernate) {
            cp = owningClass.constrainedProperties[p.name]
            display = (cp ? cp.display : true)
            required = (cp ? !(cp.propertyType in [boolean, Boolean]) && !cp.nullable && (cp.propertyType != String || !cp.blank) : false)
        }
        if (display) {
            event 'StatusUpdate', ['Checking if ' + p.type.name + ' is a domain class.']
            if (grailsApp.isDomainClass(p.type)) {
                event 'StatusUpdate', [p.type.name + ' is a domain class. Calling render.']
                println renderEditor(p, prefix, 'edit')
            } else if (p.type.name.equals("java.util.Set")) {
                event 'StatusUpdate', ["Found generic type to be: " + p.referencedPropertyType + "."]
                if (grailsApp.isDomainClass(p.referencedPropertyType)) {
                    event 'StatusUpdate', ["Generic type: " + p.type.name + ' is a domain class. Calling render.']
                    // println renderEditor(p, prefix, 'createMany') // To Do handle has many.
                    println renderEditor(p, prefix, 'edit')
                }
            } else {
                event 'StatusUpdate', [p.type.name + " not a domain class, using default rendering."]
%>
    <div class="control-group" data-ng-class="{error: errors.${prefix}\${${domainClass.name}SubPrefix}${p.name}}">
        <label class="control-label" for="${prefix}\${${domainClass.name}SubPrefix}${p.name}">${p.naturalName}</label>
        <div class="controls">
            ${renderEditor(p, prefix)}
            <span class="help-inline" data-ng-show="errors.${prefix}\${${domainClass.name}SubPrefix}${p.name}">{{errors.${prefix}\${${domainClass.name}SubPrefix}${p.name}}}</span>
        </div>
    </div>

    <% }  }   } %>
