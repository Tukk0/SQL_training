/*
Техническое задание:
Удалить из таблицы supply книги тех авторов, общее количество экземпляров книг которых в таблице book превышает 10.
*/

DELETE FROM supply
WHERE author in (
    SELECT author FROM book
    GROUP BY author
    HAVING sum(amount) > 10
    );
