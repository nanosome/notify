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

	/**
	 * @author Martin Heidegger mh@leichtgewicht.at
	 */
	public class BoolField extends Field implements IBoolField {
		
		private var _bool: Boolean;
		
		private var _changeable : Boolean;
		
		public function BoolField( value: Boolean = false, changeable: Boolean = false ) {
			super( value );
			_changeable = changeable;
		}
		
		override protected function notifyValueChange(oldValue : *, newValue : *) : void {
			_bool = value as Boolean;
			super.notifyValueChange(oldValue, newValue);
		}
		
		override public function setValue( value: * ): Boolean {
			if( !_changeable ) {
				super.setValue( value );
				return true;
			} else {
				return false;
			}
		}
		
		override public function get isChangeable(): Boolean {
			return !_changeable;
		}

		public function flip() : Boolean {
			value = !_bool;
			return _bool;
		}
		
		public function yes() : Boolean {
			if( !_bool ) {
				value = true;
				return true;
			} else {
				return false;
			}
		}
		
		public function no() : Boolean {
			if( !_bool ) {
				value = false;
				return true;
			} else {
				return false;
			}
		}
		
		public function get isTrue() : Boolean {
			return _bool;
		}
		
		public function get isFalse() : Boolean {
			return !_bool;
		}
	}
}
