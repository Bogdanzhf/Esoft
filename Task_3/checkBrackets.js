function isValidBrackets(input) {
    const stack = [];
    const pairs = {
        ')': '(',
        ']': '[',
        '}': '{'
    };
    const opening = new Set(['(', '[', '{']);

    for (const char of input) {
        if (opening.has(char)) {
            stack.push(char);
            continue;
        }

        if (pairs[char]) {
            if (stack.pop() !== pairs[char]) {
                return false;
            }
        }
    }

    return stack.length === 0;
}

const examples = [
    '',
    '()',
    '()[]{}',
    '(]',
    '([)]',
    '{[]}',
    '((({[]})))',
    '[{()}](){}'
];

for (const example of examples) {
    console.log(`Input: "${example}" -> ${isValidBrackets(example)}`);
}

module.exports = { isValidBrackets };
