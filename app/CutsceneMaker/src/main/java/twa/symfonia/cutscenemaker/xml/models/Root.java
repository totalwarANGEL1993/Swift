package twa.symfonia.cutscenemaker.xml.models;

import java.util.List;

import org.simpleframework.xml.ElementList;

@org.simpleframework.xml.Root
public class Root {
    @ElementList
    private List<Event> EventCollection;

    public List<Event> getEvent() {
        return EventCollection;
    }
}