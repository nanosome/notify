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
package nanosome.notify.bind.impl {
	import nanosome.util.access.Accessor;
	import nanosome.util.access.accessFor;
	
	import nanosome.util.UID;
	
	

	import flash.utils.Dictionary;
	
	/**
	 * @author mh
	 */
	public class PropertyRoot extends UID {
		
		private static const _registry: Dictionary = new Dictionary( true );
		private static const _nullWatcher: PropertyRoot = new PropertyRoot( null );
		
		public static function forObject( object: * ): PropertyRoot {
			if( object ) {
				var root: PropertyRoot = _registry[ object ];
				if( !root ) {
					root = _registry[ object ] = new PropertyRoot( object );
				}
				return root;
			} else {
				return _nullWatcher;
			}
		}
		
		private var _propertyWatcherMap: Dictionary;
		private var _accessor: Accessor;
		private var _target: *;
		
		public function PropertyRoot( target: * = null ) {
			_target = target;
		}
		
		public function property( name: String ): WatchField {
			if( !_accessor ) {
				_accessor = accessFor( _target );
			}
			
			if( !_propertyWatcherMap ) {
				_propertyWatcherMap = new Dictionary( true );
			}
			
			// Complex access to make use of weak references.
			for( var propertyWatcher: * in _propertyWatcherMap ) {
				if( WatchField( propertyWatcher ).lastSegment == name ) {
					return propertyWatcher;
				}
			}
			
			propertyWatcher = new WatchField( _target, name,
				_target, name, this );
			
			_propertyWatcherMap[ propertyWatcher ] = true;
			
			return propertyWatcher;
		}
	}
}
