/*
	PureMVC Haxe Demo - Feathers UI TodoMVC
	Copyright (c) 2022 Bowler Hat LLC
 */

package org.puremvc.haxe.demos.feathersui.todomvc.view.components;

import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.TextInput;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.events.TriggerEvent;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;
import org.puremvc.haxe.demos.feathersui.todomvc.model.vo.TodoItem;
import org.puremvc.haxe.demos.feathersui.todomvc.view.components.events.EditTodoItemEvent;
import org.puremvc.haxe.demos.feathersui.todomvc.view.components.events.TodoItemEvent;

class TodoItemRenderer extends ItemRenderer {
	public static final CHILD_VARIANT_DELETE_BUTTON = "todoItemRenderer_deleteButton";

	public function new() {
		super();
		this.addEventListener(MouseEvent.ROLL_OVER, todoItemRenderer_rollOverHandler);
		this.addEventListener(MouseEvent.ROLL_OUT, todoItemRenderer_rollOutHandler);
	}

	public var todoItem:TodoItem;

	private var completedCheck:Check;
	private var deleteButton:Button;
	private var editingTextInput:TextInput;

	private var _ignoreCompletedCheckChange:Bool;

	public var completed(get, never):Bool;

	private function get_completed():Bool {
		if (this.todoItem == null) {
			return false;
		}
		return this.todoItem.completed;
	}

	override private function initialize():Void {
		super.initialize();

		this.textField.doubleClickEnabled = true;
		this.textField.addEventListener(MouseEvent.DOUBLE_CLICK, textField_doubleClickHandler);

		this.completedCheck = new Check();
		this.completedCheck.addEventListener(Event.CHANGE, completedCheck_changeHandler);
		this.icon = this.completedCheck;

		this.deleteButton = new Button();
		this.deleteButton.variant = CHILD_VARIANT_DELETE_BUTTON;
		this.deleteButton.tabEnabled = false;
		this.deleteButton.addEventListener(TriggerEvent.TRIGGER, deleteButton_triggerHandler);

		this.editingTextInput = new TextInput();
		this.editingTextInput.visible = false;
		this.editingTextInput.addEventListener(FocusEvent.FOCUS_OUT, editingTextInput_focusOutHandler);
		this.editingTextInput.addEventListener(KeyboardEvent.KEY_DOWN, editingTextInput_keyDownHandler);
		this.addChild(this.editingTextInput);
	}

	override private function update():Void {
		this._ignoreCompletedCheckChange = true;
		if (this.todoItem != null) {
			this.text = this.todoItem.text;
			this.completedCheck.selected = this.todoItem.completed;
		} else {
			this.text = "";
			this.completedCheck.selected = false;
		}
		this._ignoreCompletedCheckChange = false;

		super.update();
	}

	override private function layoutChildren():Void {
		super.layoutChildren();

		this.editingTextInput.x = this.textField.x;
		this.editingTextInput.y = 0.0;
		this.editingTextInput.width = this.actualWidth - this.editingTextInput.x;
		this.editingTextInput.height = this.actualHeight;
	}

	private function commitUserChanges():Void {
		var newText = this.editingTextInput.text;
		this.cancelUserChanges();
		this.dispatchEvent(new EditTodoItemEvent(EditTodoItemEvent.EDIT_TODO_ITEM, this.todoItem, newText));
	}

	private function cancelUserChanges():Void {
		this.editingTextInput.visible = false;
		this.editingTextInput.text = "";
	}

	private function completedCheck_changeHandler(event:Event):Void {
		if (this.completedCheck.selected == this.todoItem.completed) {
			return;
		}
		this.dispatchEvent(new TodoItemEvent(TodoItemEvent.TOGGLE_COMPLETED, this.todoItem));
	}

	private function deleteButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new TodoItemEvent(TodoItemEvent.REMOVE_TODO_ITEM, this.todoItem));
	}

	private function todoItemRenderer_rollOverHandler(event:MouseEvent):Void {
		if (this.editingTextInput.visible) {
			return;
		}
		this.accessoryView = this.deleteButton;
	}

	private function todoItemRenderer_rollOutHandler(event:MouseEvent):Void {
		this.accessoryView = null;
	}

	private function textField_doubleClickHandler(event:MouseEvent):Void {
		this.accessoryView = null;
		this.editingTextInput.text = this.text;
		this.editingTextInput.visible = true;
		this.focusManager.focus = this.editingTextInput;
		this.editingTextInput.selectAll();
	}

	private function editingTextInput_focusOutHandler(event:FocusEvent):Void {
		if (!this.editingTextInput.visible) {
			return;
		}
		this.commitUserChanges();
	}

	private function editingTextInput_keyDownHandler(event:KeyboardEvent):Void {
		if (event.isDefaultPrevented() || event.keyCode != Keyboard.ENTER) {
			return;
		}
		switch (event.keyCode) {
			case Keyboard.ENTER:
				this.commitUserChanges();
			case Keyboard.ESCAPE:
				this.cancelUserChanges();
		}
	}
}
