//  
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License. 
// 

package nanosome.notify.field.bool {
	import nanosome.notify.field.Field;
	import nanosome.notify.field.IBoolField;
	import nanosome.notify.field.IField;
	import nanosome.notify.field.IFieldObserver;

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class BoolFieldWrapper extends Field implements IBoolField, IFieldObserver {
		
		private var _target: IField;
		
		public function BoolFieldWrapper( target: IField ) {
			super( null );
			if( !target ) {
				throw new Error( "Target MO is required to see if its not." );
			}
			_target = target;
		}
		
		override public function dispose(): void {
			super.dispose();
			_target.removeObserver( this );
			_target = null;
		}
		
		override public function addObserver( observer: IFieldObserver,
						executeImmediatly: Boolean = false, weakReference: Boolean = false): Boolean {
			if( super.addObserver(observer, executeImmediatly, weakReference) ) {
				// Only add as observer if there is a observer on this one
				_target.addObserver( this );
				return true;
			} else {
				return false;
			}
		}
		
		override public function removeObserver( observer: IFieldObserver ): Boolean {
			if( super.removeObserver( observer ) ) {
				if( !hasObservers ) {
					_target.removeObserver( this );
				}
				return true;
			} else {
				return false;
			}
		}
		
		override public function setValue( value: * ): Boolean {
			return _target.setValue( value );
		}
		
		override public function get value(): * {
			return _target.value;
		}
		
		override public function get isChangeable(): Boolean {
			return _target.isChangeable;
		}
		
		public function flip() : Boolean {
			if( isTrue ) {
				return no();
			} else {
				return yes();
			}
		}
		
		public function yes(): Boolean {
			return _target.setValue( true );
		}
		
		public function no(): Boolean {
			return _target.setValue( false );
		}
		
		public function get isTrue(): Boolean {
			return _target.value;
		}
		
		public function get isFalse(): Boolean {
			return !_target.value;
		}
		
		public function onFieldChange( mo: IField, oldValue: * = null, newValue: * = null ): void {
			notifyValueChange( oldValue, newValue );
		}
	}
}
