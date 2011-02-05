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
package nanosome.notify.observe {
	
	
	import nanosome.util.ILockable;
	import nanosome.util.IUID;
	import nanosome.util.UID;
	
	/**
	 * <code>Observable</code> is a util to easily implement <code>IPropertyObservable</code>.
	 * 
	 * <p>The implementation can be handled by simply extending <code>Observable</code>. It
	 * will be more code that using [Bindable] (as a competing way to achieve that)
	 * but it will be more effient.</p>
	 * 
	 * @example
	 *   <code>
	 *     class MyObservable extends Observable {
	 *       private var _member: *;
	 *       
	 *       public function set member( member: * ): void {
	 *         if( member != _member ) notifyPropertyChanged( "member", _member, _member = member );
	 *       }
	 *       
	 *       public function get member(): * {
	 *         return _member;
	 *       }
	 *     }
	 *   </code>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see IPropertyObservable
	 */
	public class Observable
					extends UID
					implements IPropertyObservable, ILockable, IUID {
		
		// Internal broadcaster used to handle all that heavy lifting
		private const _broadcaster: PropertyBroadcaster = new PropertyBroadcaster();
		
		/**
		 * Constructs the new <code>Observerable</code>
		 */
		public function Observable() {
			_broadcaster.target = this;
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose(): void {
			_broadcaster.dispose();
		}
		
		/**
		 * @inheritDoc
		 */
		public final function lock(): void {
			locked = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public final function unlock(): void {
			locked = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set locked( locked: Boolean ): void {
			_broadcaster.locked = locked;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get locked(): Boolean {
			return _broadcaster.locked;
		}
		
		/**
		 * @inheritDoc
		 */
		public final function addPropertyObserver( observer: IPropertyObserver, weak: Boolean = false ): Boolean {
			return _broadcaster.add( observer, weak );
		}
		
		/**
		 * @inheritDoc
		 */
		public final function removePropertyObserver( observer: IPropertyObserver ): Boolean {
			return _broadcaster.remove( observer );
		}
		
		/**
		 * Notifies all the observers about a change
		 * 
		 * @param name Name of the property that changed
		 * @param oldValue Value that the property had prior to the change
		 * @param newValue Value that the property has now
		 */
		protected final function notifyPropertyChange( name: String, oldValue: *, newValue: * ): void {
			_broadcaster.notifyPropertyChange( name, oldValue, newValue );
		}
	}
}
