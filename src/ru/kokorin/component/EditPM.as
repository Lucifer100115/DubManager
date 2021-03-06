package ru.kokorin.component {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.events.PropertyChangeEvent;

import mx.logging.ILogger;

import ru.kokorin.astream.AStream;
import ru.kokorin.util.LogUtil;

[Event(name="open", type="flash.events.Event")]
[Event(name="close", type="flash.events.Event")]
[Event(name="save", type="ru.kokorin.component.EditEvent")]
public class EditPM extends EventDispatcher {
    private var itemClazz:Class;
    private var _item:Object;
    private var _original:Object;
    public const aStream:AStream = new AStream();

    protected const LOGGER:ILogger = LogUtil.getLogger(this);

    public function EditPM(itemClazz:Class) {
        this.itemClazz = itemClazz;
    }

    [Bindable(event="open")]
    [Bindable(event="close")]
    public function get isOpen():Boolean {
        return _item != null;
    }

    [Bindable(event="open")]
    [Bindable(event="close")]
    public function get item():Object {
        return _item;
    }

    public function open(item:Object = null, changed:Boolean = false):void {
        LOGGER.debug("Opening {0}", item);
        if (item == null) {
            _item = new itemClazz();
        } else {
            _item = aStream.fromXML(aStream.toXML(item));
        }
        _original = item;
        dispatchEvent(new Event(Event.OPEN));

        if (changed) {
            const itemDispatcher:IEventDispatcher = _item as IEventDispatcher;
            if (itemDispatcher) {
                itemDispatcher.dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE));
            }
        }
    }

    public function save():void {
        const event:EditEvent = new EditEvent(EditEvent.SAVE);
        event.item = _item;
        event.original = _original;
        dispatchEvent(event);
        if (!event.isDefaultPrevented()) {
            close();
        }
    }

    public function close():void {
        LOGGER.debug("Closing dialog");
        _item = null;
        _original = null;
        dispatchEvent(new Event(Event.CLOSE));
    }
}
}