function deepClone(value, cache = new WeakMap()) {
    if (value === null || typeof value !== 'object' && typeof value !== 'function') {
        return value;
    }

    if (cache.has(value)) {
        return cache.get(value);
    }

    if (value instanceof Date) {
        return new Date(value.getTime());
    }

    if (value instanceof RegExp) {
        const clonedRegExp = new RegExp(value.source, value.flags);
        clonedRegExp.lastIndex = value.lastIndex;
        return clonedRegExp;
    }

    if (value instanceof Map) {
        const clonedMap = new Map();
        cache.set(value, clonedMap);

        for (const [key, mapValue] of value.entries()) {
            clonedMap.set(deepClone(key, cache), deepClone(mapValue, cache));
        }

        return clonedMap;
    }

    if (value instanceof Set) {
        const clonedSet = new Set();
        cache.set(value, clonedSet);

        for (const item of value.values()) {
            clonedSet.add(deepClone(item, cache));
        }

        return clonedSet;
    }

    if (ArrayBuffer.isView(value)) {
        return new value.constructor(value);
    }

    if (value instanceof ArrayBuffer) {
        return value.slice(0);
    }

    if (value instanceof Error) {
        const clonedError = new value.constructor(value.message);
        cache.set(value, clonedError);
        copyProperties(value, clonedError, cache);
        return clonedError;
    }

    if (typeof value === 'function') {
        const clonedFunction = function (...args) {
            if (new.target) {
                return Reflect.construct(value, args, new.target);
            }

            return value.apply(this, args);
        };

        cache.set(value, clonedFunction);
        Object.setPrototypeOf(clonedFunction, Object.getPrototypeOf(value));
        copyProperties(value, clonedFunction, cache);
        return clonedFunction;
    }

    const clonedObject = Array.isArray(value)
        ? []
        : Object.create(Object.getPrototypeOf(value));

    cache.set(value, clonedObject);
    copyProperties(value, clonedObject, cache);

    return clonedObject;
}

function copyProperties(source, target, cache) {
    const descriptors = Object.getOwnPropertyDescriptors(source);

    for (const key of Reflect.ownKeys(descriptors)) {
        const descriptor = descriptors[key];

        if ('value' in descriptor) {
            descriptor.value = deepClone(descriptor.value, cache);
        }

        if (descriptor.get) {
            descriptor.get = deepClone(descriptor.get, cache);
        }

        if (descriptor.set) {
            descriptor.set = deepClone(descriptor.set, cache);
        }
    }

    Object.defineProperties(target, descriptors);
}

const secretKey = Symbol('secret');

const original = {
    title: 'Deep copy',
    createdAt: new Date('2026-03-30T10:00:00'),
    data: {
        numbers: [1, 2, 3],
        map: new Map([
            ['user', { name: 'Bogdan' }]
        ]),
        set: new Set(['html', 'css', 'js'])
    },
    greet(name) {
        return `Hello, ${name}`;
    },
    [secretKey]: 'symbol value'
};

original.self = original;

const copy = deepClone(original);
copy.title = 'Changed copy';
copy.data.numbers.push(4);
copy.data.map.get('user').name = 'Alex';

console.log('Original title:', original.title);
console.log('Copy title:', copy.title);
console.log('Original numbers:', original.data.numbers);
console.log('Copy numbers:', copy.data.numbers);
console.log('Original map name:', original.data.map.get('user').name);
console.log('Copy map name:', copy.data.map.get('user').name);
console.log('Cycle works:', copy.self === copy);
console.log('Prototype preserved:', Object.getPrototypeOf(copy) === Object.getPrototypeOf(original));
console.log('Symbol value:', copy[secretKey]);
console.log('Function call:', copy.greet('student'));

module.exports = { deepClone };
